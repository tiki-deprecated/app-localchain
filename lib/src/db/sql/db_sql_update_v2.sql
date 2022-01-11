/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */


DROP TABLE IF EXISTS block;
DROP TABLE IF EXISTS cache;

-- -----------------------------------------------------------------------
-- BLOCK
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS block(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contents BLOB NOT NULL,
    previous_hash BLOB NOT NULL,
    created_epoch INTEGER NOT NULL
);

INSERT INTO block (contents, previous_hash, created_epoch)
VALUES ('_START_BLOCK', '', strftime('%s', 'now') * 1000);