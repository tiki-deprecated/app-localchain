/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

-- -----------------------------------------------------------------------
-- BLOCK
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS block(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contents TEXT NOT NULL,
    previous_hash TEXT NOT NULL,
    created_epoch INTEGER NOT NULL
);
