'use strict'

const { faker } = require('@faker-js/faker');
const AWS = require("aws-sdk");
const os = require("os")

const sqs = new AWS.SQS();


exports.handler = (event, context, callback) => {

    const date = new Date()
    const key = date.toISOString().slice(0, 10)

    console.log("Key:", key)

    console.log("Sending messages:", process.env.NUMBER_OF_MESSAGES)
    
    let v = 0;
    while (v <= process.env.NUMBER_OF_MESSAGES) {

        let payment_data = {
            id: faker.datatype.uuid(),
            name: faker.name.firstName(),
            last_name: faker.name.lastName(),
            amount: faker.finance.amount(),
            description: faker.lorem.paragraph(),
            vehicle: faker.vehicle.vehicle(),
            country: faker.address.country()
        }

        let body = JSON.stringify(payment_data)

        let params = {
           MessageBody: body,
           QueueUrl: process.env.SQS_QUEUE
         };

        console.log("Payload: ", params)


        const save = sqs.sendMessage(params).promise()

        save
            .then(ok => {
                console.log(ok)
            })
            .catch(err => context.fail(err))
            v++
    }

}