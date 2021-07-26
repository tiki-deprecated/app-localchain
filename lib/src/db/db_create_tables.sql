/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

-- -----------------------------------------------------------------------
-- BLOCK
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS block(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contents BLOB NOT NULL,
    signature BLOB NOT NULL,
    previous_hash BLOB NOT NULL,
    created_epoch INTEGER NOT NULL
);

-- -----------------------------------------------------------------------
-- CACHE
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cache(
    block_id INTEGER PRIMARY KEY,
    contents BLOB NOT NULL,
    cached_epoch INTEGER NOT NULL,
    FOREIGN KEY(block_id) REFERENCES block(id)
);
