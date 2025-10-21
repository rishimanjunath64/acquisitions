// src/db/index.js

import 'dotenv/config';
import { neon } from '@neondatabase/serverless';
import { drizzle as drizzleNeon } from 'drizzle-orm/neon-http';
import { drizzle as drizzlePg } from 'drizzle-orm/node-postgres';
import pg from 'pg';

const DATABASE_URL = process.env.DATABASE_URL;

// Use node-postgres for Docker/Neon Local, neon-http for production
let db, sql;

if (
  process.env.NODE_ENV === 'development' &&
  DATABASE_URL.includes('neon-local')
) {
  // Docker environment with Neon Local - use standard PostgreSQL driver
  const pool = new pg.Pool({
    connectionString: DATABASE_URL,
  });
  db = drizzlePg(pool);
  sql = pool;
} else {
  // Production or local dev (non-Docker) - use Neon HTTP driver
  sql = neon(DATABASE_URL);
  db = drizzleNeon(sql);
}

export { db, sql };
