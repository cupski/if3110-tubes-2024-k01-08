-- Users
CREATE TYPE user_role AS ENUM ('jobseeker', 'company');

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role user_role NOT NULL
);

-- Company Details
CREATE TABLE company_details (
  user_id INTEGER PRIMARY KEY,
  location VARCHAR(255) NOT NULL,
  about TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);


-- job Kerja
CREATE TYPE job_type_enum AS ENUM ('full-time', 'part-time', 'internship');

CREATE TYPE location_type_enum AS ENUM ('on-site', 'hybrid', 'remote');

CREATE TABLE jobs (
  job_id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL,
  position VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  job_type job_type_enum NOT NULL,
  location_type location_type_enum NOT NULL,
  is_open BOOLEAN DEFAULT true NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (company_id) REFERENCES users(id)
);

-- Attachment job
CREATE TABLE job_attachments (
    attachment_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    file_path VARCHAR(255) NOT NULL,

    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE
);

-- application
CREATE TYPE application_status_enum AS ENUM ('accepted', 'rejected', 'waiting');

CREATE TABLE applications (
    application_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    job_id INTEGER NOT NULL,
    cv_path VARCHAR(255) NOT NULL,
    video_path VARCHAR(255),
    status application_status_enum DEFAULT 'waiting',
    status_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (user_id, job_id), -- One user can only apply once for a job

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE
);


-- Trigger for updated at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER 
LANGUAGE PLpgSQL AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER update_jobs_updated_at
BEFORE UPDATE ON jobs
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();


-- Trigger to validate that user_id on jobs and company_details is referencing to a company
CREATE OR REPLACE FUNCTION validate_company_user()
RETURNS TRIGGER
LANGUAGE PLpgSQL AS $$
BEGIN
  IF (SELECT role FROM users WHERE id = NEW.user_id) <> 'company' THEN
    RAISE EXCEPTION 'User with id % is not a company', NEW.user_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER validate_company_user_on_company_details
BEFORE INSERT ON company_details
FOR EACH ROW
EXECUTE FUNCTION validate_company_user();


-- Trigger to validate that company_id on jobs is referencing to a company
CREATE OR REPLACE FUNCTION validate_company_id()
RETURNS TRIGGER
LANGUAGE PLpgSQL AS $$
BEGIN
  IF (SELECT role FROM users WHERE id = NEW.company_id) <> 'company' THEN
    RAISE EXCEPTION 'User with id % is not a company', NEW.company_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER validate_company_id_on_jobs
BEFORE INSERT ON jobs
FOR EACH ROW
EXECUTE FUNCTION validate_company_id();


-- Trigger to validate that user_id on application is referencing to a jobseeker
CREATE OR REPLACE FUNCTION validate_jobseeker_user()
RETURNS TRIGGER
LANGUAGE PLpgSQL AS $$
BEGIN
  IF (SELECT role FROM users WHERE id = NEW.user_id) <> 'jobseeker' THEN
    RAISE EXCEPTION 'User with id % is not a jobseeker', NEW.user_id;
  END IF;

  RETURN NEW;
END
$$;

CREATE OR REPLACE TRIGGER validate_jobseeker_user_on_applications
BEFORE INSERT ON applications
FOR EACH ROW
EXECUTE FUNCTION validate_jobseeker_user();

-- Seed data
-- Function to generate random text
CREATE OR REPLACE FUNCTION random_text(min_length INT, max_length INT) RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    possible_chars TEXT := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
    text_length INT;
BEGIN
    text_length := floor(random() * (max_length - min_length + 1) + min_length)::INT;
    FOR i IN 1..text_length LOOP
        result := result || substr(possible_chars, floor(random() * length(possible_chars) + 1)::INT, 1);
    END LOOP;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Users
INSERT INTO users (name, email, password, role) VALUES
('jobseeker1', 'jobseeker1@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker2', 'jobseeker2@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker3', 'jobseeker3@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker4', 'jobseeker4@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker5', 'jobseeker5@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker6', 'jobseeker6@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker7', 'jobseeker7@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker8', 'jobseeker8@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker9', 'jobseeker9@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('jobseeker10', 'jobseeker10@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker'),
('company1', 'company1@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company2', 'company2@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company3', 'company3@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company4', 'company4@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company5', 'company5@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company6', 'company6@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),  
('company7', 'company7@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company8', 'company8@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),  
('company9', 'company9@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('company10', 'company10@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('Dewo', 'dewo@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'company'),
('Bas', 'bas@gmail.com', '$2y$10$TU9rBqa2AMCjlPlKuN/KxujIvnhfVteNxygzoOVhdvEEzVW5kkDpW', 'jobseeker');

-- Company Details for all 10 companies (user_id 11-20)
INSERT INTO company_details (user_id, location, about) VALUES
(11, 'New York, USA', 'Leading technology company specializing in AI solutions'),
(12, 'London, UK', 'Global financial services provider with innovative fintech products'),
(13, 'Tokyo, Japan', 'Pioneer in robotics and automation systems'),
(14, 'Jakarta, Indonesia', 'Southeast Asia''s largest e-commerce platform'),
(15, 'Singapore', 'Leading telecommunications and digital services provider'),
(16, 'Sydney, Australia', 'Innovative startup in renewable energy solutions'),
(17, 'Berlin, Germany', 'Advanced manufacturing and engineering company'),
(18, 'Toronto, Canada', 'Healthcare technology and research organization'),
(19, 'Dubai, UAE', 'International consulting and business services firm'),
(20, 'São Paulo, Brazil', 'Leading software development and IT services company');

-- Jobs Posting (1000 for each company, 10000 total)
INSERT INTO jobs (company_id, position, description, job_type, location_type, is_open, created_at, updated_at)
SELECT 
    company_id,
    'Position ' || job_number,
    '<h2>Job Description</h2><p>' || random_text(100, 500) || '</p><h3>Requirements</h3><ul><li>' || random_text(10, 50) || '</li><li>' || random_text(10, 50) || '</li><li>' || random_text(10, 50) || '</li></ul>',
    (ARRAY['full-time', 'part-time', 'internship']::job_type_enum[])[floor(random() * 3 + 1)],
    (ARRAY['on-site', 'hybrid', 'remote']::location_type_enum[])[floor(random() * 3 + 1)],
    random() > 0.2,
    now() - (random() * (interval '90 days')),
    now() - (random() * (interval '30 days'))
FROM (
    SELECT 
        company_id,
        generate_series % 1000 + 1 as job_number
    FROM 
        generate_series(1, 10000),
        (SELECT generate_series(11, 20) as company_id) c
) subquery;

-- Job Attachments (3 attachments per job, 30000 total)
INSERT INTO job_attachments (job_id, file_path)
SELECT 
    ceil(generate_series / 3.0),
    '/uploads/jobs/attachment_' || generate_series || '.jpg'
FROM generate_series(1, 30000);

-- Applications (100 unique applications per job seeker, 1000 total per job seeker)
WITH job_seeker_applications AS (
    SELECT 
        user_id,
        job_id,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY random()) AS row_num
    FROM 
        (SELECT id as user_id FROM users WHERE role = 'jobseeker' AND id <= 10) u
    CROSS JOIN 
        (SELECT job_id FROM jobs ORDER BY random()) j
)
INSERT INTO applications (user_id, job_id, cv_path, video_path, status, status_reason, created_at)
SELECT 
    user_id,
    job_id,
    '/uploads/applications/jobs/' || job_id || '/users/' || user_id || '/cv/cv_' || (ROW_NUMBER() OVER ()) || '.pdf',
    CASE WHEN random() > 0.5 
        THEN '/uploads/applications/jobs/' || job_id || '/users/' || user_id || '/video/video_' || (ROW_NUMBER() OVER ()) || '.mp4' 
        ELSE NULL 
    END,
    (ARRAY['accepted', 'rejected', 'waiting']::application_status_enum[])[floor(random() * 3 + 1)],
    CASE 
        WHEN (ARRAY['accepted', 'rejected', 'waiting']::application_status_enum[])[floor(random() * 3 + 1)] = 'rejected' 
        THEN '<p>We regret to inform you that your application has been rejected. ' || random_text(50, 200) || '</p>'
        ELSE NULL
    END,
    now() - (random() * (interval '60 days'))
FROM job_seeker_applications
WHERE row_num <= 100;
-- Update users sequence
SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT MAX(id) FROM users));

-- Update jobs sequence
SELECT setval(pg_get_serial_sequence('jobs', 'job_id'), (SELECT MAX(job_id) FROM jobs));

-- Update job_attachments sequence
SELECT setval(pg_get_serial_sequence('job_attachments', 'attachment_id'), (SELECT MAX(attachment_id) FROM job_attachments));

-- Update applications sequence
SELECT setval(pg_get_serial_sequence('applications', 'application_id'), (SELECT MAX(application_id) FROM applications));