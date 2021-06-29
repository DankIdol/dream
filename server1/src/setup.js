const { Pool, Client } = require('pg')

module.exports = {
    setup: () => {
        const pool = new Pool()
        const CREATE = 
            "create table scores(id serial primary key, name varchar(12) unique not null, score int not null)"

        pool
            .query(CREATE)
            .then(res => console.log(res))
            .catch(err => console.error(err.stack))
    }
}