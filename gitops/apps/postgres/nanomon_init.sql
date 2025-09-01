--- Check if the current database is 'nanomon' prevents accidental execution on the wrong database
SELECT current_database() AS db_name;
DO $$
BEGIN
    IF current_database() != 'nanomon' THEN
        RAISE EXCEPTION 'This script should only be run on the nanomon database!';
    END IF;
END $$; 


-- Create monitors table
CREATE TABLE monitors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  type VARCHAR(100) NOT NULL,
  interval VARCHAR(50) NOT NULL,
  target VARCHAR(512) NOT NULL,
  rule VARCHAR(255) NOT NULL,
  enabled BOOLEAN DEFAULT TRUE,
  updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  group_name VARCHAR(100) DEFAULT 'default',
  properties JSONB DEFAULT '{}'::JSONB
); 

-- Create results table
CREATE TABLE results (
  id SERIAL PRIMARY KEY,
  date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  monitor_id INT REFERENCES monitors(id) ON DELETE CASCADE,
  monitor_name VARCHAR(100) NOT NULL,
  monitor_target VARCHAR(512) NOT NULL,
  status INT NOT NULL,
  value DOUBLE PRECISION NOT NULL,
  message VARCHAR(512) DEFAULT '',
  outputs JSONB DEFAULT '{}'::JSONB
);

-- Add indexes
CREATE INDEX idx_monitor_id ON results(monitor_id);
CREATE INDEX idx_date ON results(date);

-- Function to notify on new monitor insertion
CREATE OR REPLACE FUNCTION notify_monitor_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Send notification with the new monitor data as JSON
    PERFORM pg_notify('new_monitor', 
        json_build_object(
          'id', NEW.id,
          'name', NEW.name,
          'type', NEW.type,
          'interval', NEW.interval,
          'target', NEW.target,
          'rule', NEW.rule,
          'enabled', NEW.enabled,
          'updated', NEW.updated,
          'group', NEW.group_name,
          'properties', NEW.properties
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to notify on monitor updates
CREATE OR REPLACE FUNCTION notify_monitor_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Send notification with the updated monitor data as JSON
    PERFORM pg_notify('monitor_updated', 
        json_build_object(
            'id', NEW.id,
            'name', NEW.name,
            'type', NEW.type,
            'interval', NEW.interval,
            'target', NEW.target,
            'rule', NEW.rule,
            'enabled', NEW.enabled,
            'updated', NEW.updated,
            'group', NEW.group_name,
            'properties', NEW.properties
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to notify on monitor deletion
CREATE OR REPLACE FUNCTION notify_monitor_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Send notification with the deleted monitor id as text
    PERFORM pg_notify('monitor_deleted', OLD.id::text);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that fires after INSERT on monitors table
CREATE TRIGGER monitor_insert_trigger
    AFTER INSERT ON monitors
    FOR EACH ROW
    EXECUTE FUNCTION notify_monitor_insert();

-- Create trigger that fires after UPDATE on monitors table
CREATE TRIGGER monitor_update_trigger
    AFTER UPDATE ON monitors
    FOR EACH ROW
    EXECUTE FUNCTION notify_monitor_update();

-- Create trigger that fires after DELETE on monitors table
CREATE TRIGGER monitor_delete_trigger
    AFTER DELETE ON monitors
    FOR EACH ROW
    EXECUTE FUNCTION notify_monitor_delete();
