INSERT INTO
    roles (name)
VALUES
    ('Admin'),
    ('User')
ON CONFLICT DO NOTHING;

INSERT INTO
    users (name, email, password_hash, role_id)
SELECT
    'Eleazar Fig',
    'eleazar.fig@example.com',
    '$2b$12$F3Gp7dGRfEGAVJ4PovobbeJiuu4nfxFtuTgqV1/GHBNXjY05pLsD2',
    role_id
FROM roles
WHERE
    name LIKE 'Admin';