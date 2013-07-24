SELECT setval('user_id_seq', 10, true);
SELECT setval('role_id_seq', 10, true);


-- all passwords are 12345

INSERT INTO "role"(id, name)
VALUES
(0,'superadmin'),
(1,'admin'),
(3,'user');
-- ...


INSERT INTO "user"(id, name, email, password) VALUES (1, 'superadmin','superadmin@email.com', '$2a$08$Hys9hzza605zZVKNJvdiBe9bHfdB4JKFnG8douGv53IW4e9M5cKrW');
INSERT INTO "user"(id, name, email, password) VALUES (2, 'admin','admin@email.com', '$2a$08$Hys9hzza605zZVKNJvdiBe9bHfdB4JKFnG8douGv53IW4e9M5cKrW');




-- role: superadmin                                     user:
INSERT INTO "user_role" ( user_id, role_id) VALUES (1, 0); -- superadmin
INSERT INTO "user_role" ( user_id, role_id) VALUES (1, 1); -- admin

-- role: admin                                          user:
INSERT INTO "user_role" ( user_id, role_id) VALUES (2, 1); -- admin


