const { Pool, Client } = require('pg')
const express = require('express')
const bodyParser = require('body-parser')
const setup = require('./setup')

const pool = new Pool()

const FIND_EXIST = "select id, score from scores where name=$1"
const GET_RECORDS = "select *, row_number() over (order by score desc) from scores"
const INSERT_NEW = "insert into scores (name, score) values ($1, $2) returning id"
const UPDATE = "update scores set score=$1 where id=$2"

const app = express()
app.use(bodyParser.json({ extended: true }))
const port = process.env.PORT || 3000
const key = process.env.KEY || "sample_key" //thisisnotthekey sha256

app.get("/ping", (req, res) => res.send("pong") )

app.get("/setup", (req, res) => {
	setup.setup()
	res.send('OK')
})

app.post('/postgres', (req, res) => {
	pool
		.query(req.body.command)
		.then(res => console.log(res))
		.catch(e => console.error(e.stack))
	res.send('OK')
})

app.post('/data', (req, res) => {

	if(req.body.key != key)
		res.status(401).json({ reason: "go away" })
	else {
		let id

		pool
		.query(FIND_EXIST, [req.body.name], (err, result) => {
			if(err) console.error(err.stack)
			else {
				if(result.rows.length < 1) {
					// NEW PLAYER
					console.log(`adding player ${req.body.name}`)

					pool
					.query(INSERT_NEW, [req.body.name, req.body.score], (err, result) => {
						if(err) console.error(err.stack)
						else {
							id = result.rows[0].id
							console.log(`added player ${req.body.name} with id ${id}`)
						}
					})
				} else {
					// EXISTING PLAYER
					id = result.rows[0].id
					let score = result.rows[0].score
					console.log(`updating player ${req.body.name} with score ${req.body.score}, previous score is ${score}`)
					if(score < req.body.score){
						pool
						.query(UPDATE, [req.body.score, result.rows[0].id], (err, result) => {
							if(err) console.error(err)
							else console.log(`updated player ${req.body.name}`)
						})
					}
				}
			}

			pool
			.query(GET_RECORDS, (err, result) => {
				if(err) console.error(err.stack)
				else {
					let top = result.rows.slice(0, 10)
					let player = result.rows.filter(el => el.id == id)

					let payload = {
						top: top,
						you: player
					}

					res.status(200).json(payload)
				}
			})

		})
	}

})

app.post("/name", (req, res) => {
	pool.query(FIND_EXIST, [req.body.name], (err, result) => {
		console.log(JSON.stringify(result))
		if(result.rows.length > 0)
			res.status(200).json({ exists: true })
		else {
			pool.query(INSERT_NEW, [req.body.name, 0], (err, result) => {
				if(err) console.log(err)
				else console.log(`user ${req.body.name} created`)

				res.status(200).json({ exists: false })
			})
		}
	})
})

app.get("/dreamer/:username", (req, res) => {
	let name = req.params.username
	pool
	.query(GET_RECORDS, (err, result) => {
		if(err) console.error(err.stack)
		else {
			console.log(`generating website for ${name}`)
			let player = result.rows.filter(el => el.name == name)
			if(player.length > 0)
				res.status(200).json(player[0])
			else
				res.status(404).json("")
		}
	})
})

app.post("/all", (req, res) => {
	pool
	.query(GET_RECORDS, (err, result) => {
		if(err) console.error(err.stack)
		else {
			console.log(`generating leaderboard for ${req.body.name}`)
			let top = result.rows.slice(0, 10)
			let player = result.rows.filter(el => el.name == req.body.name)

			if(player.length > 0)
				player = player[0]
			else
				player = {"name": "how did this happen"}

			let payload = {
				top: top,
				you: player
			}

			res.status(200).json(payload)
		}
	})
})

app.listen(port, () => {
  console.log(`app listening at http://localhost:${port}`)
})