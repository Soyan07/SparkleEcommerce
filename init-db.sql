-- PostgreSQL initialization script for Render deployment
-- This script runs when the PostgreSQL database is created
-- EF Core will create all tables and schema automatically

-- Enable UUID extension for potential use
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log initialization (this runs once when database is created)
DO $$
BEGIN
    RAISE NOTICE 'SparkleEcommerce PostgreSQL database initialized successfully';
END $$;
