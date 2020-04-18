import express from 'express'
const app = express()

app.get('/', (req, res) => {
    res.send('Hello world')
})

const server = app.listen(1234, () => {
    const host = server.address()
    const port = server.address()
    console.log('应用实例，访问地址为 http://%s:%s', host, port)
})
