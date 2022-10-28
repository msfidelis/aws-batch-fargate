'use strict'

var AWS = require('aws-sdk');

AWS.config.update({region: 'us-east-1a'});

var sqs = new AWS.SQS({apiVersion: '2012-11-05'});

var queueURL = "https://sqs.us-east-1.amazonaws.com/181560427716/aws-batch-demo";

var params = {
    AttributeNames: [
       "SentTimestamp"
    ],
    MaxNumberOfMessages: 10,
    MessageAttributeNames: [
       "All"
    ],
    QueueUrl: queueURL,
    VisibilityTimeout: 20,
    WaitTimeSeconds: 20
};

sqs.receiveMessage(params, (err, data) =>  {
    if (err) {
        console.log(err)
    }
    const messages = data.Messages.map(m => {
        return new Promise((resolve, reject) => {
            console.log("Recived Message", m.Body)
            sqs.deleteMessage({
                QueueUrl: queueURL,
                ReceiptHandle: m.ReceiptHandle
            }, (err, data) => {
                if (err) {
                    console.log(err)
                    reject(err)
                }
                console.log("Message deleted:", data)
                resolve(m)
            })
        });
    })
})

console.log('fodase')
console.log(process.env)