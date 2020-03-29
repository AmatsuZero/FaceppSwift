const express = require('express')
const app = express()
const Cli = require('./cli')

app.get('/', (req, res) => {
    res.send('Hello world')
})

const server = app.listen(1234, () => {
    const host = server.address().address
    const port = server.address().port
    console.log('应用实例，访问地址为 http://%s:%s', host, port)
})
