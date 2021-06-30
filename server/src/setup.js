const { Pool, Client } = require('pg')

const connectionString = process.env.DATABASE_URL
const pool = new Pool({ connectionString })

const CREATE = "create table scores(id serial primary key, name varchar(12) unique not null, score int not null)"

module.exports = {
    setup: () => {
        pool
            .query(CREATE)
            .then(res => console.log(res))
            .catch(err => console.error(err.stack))
    }
}