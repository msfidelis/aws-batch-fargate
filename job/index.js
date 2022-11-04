'use strict'

const AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-1a'});

const sqs = new AWS.SQS({apiVersion: '2012-11-05'});

const queueURL      = process.env["SQS_QUEUE"] || "https://sqs.us-east-1.amazonaws.com/181560427716/aws-batch-demo";
const job_timeout   = process.env["JOB_TIMEOUT"] || 500

const params = {
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

const stop = () => {
    clearInterval(interval);
}

const consume = () => {

}

const ack = (messages) => {

    // Support to single ACK
    if (Array.isArray(messages) == false) {
        messages = [ messages ]
    }

    const promisesToResolve = messages.map((async m => {
        const params = {
            QueueUrl: queueURL,
            ReceiptHandle: m.ReceiptHandle
        }
        let d = await sqs.deleteMessage(params).promise()
        return d
    }))

    Promise.all(promisesToResolve)
        .then(success => {
            console.log("Messages deleted on SQS: ", success)
        })
        .catch(err => {
            console.log("Error to delete messages", err)
        })
}

var interval = setInterval(() => {
    sqs.receiveMessage(params, (err, data) =>  {
        if (err) {
            console.log(err)
            interval = null
        }
       
        if (data.Messages != undefined) {
            data.Messages.forEach((element, i) => {
                i++
                console.log("Message consumed", element.Body)

                if (i == data.Messages.length) {
                    ack(data.Messages)
                }
            });
        }
        
    })
}, 500)

setTimeout(() => {
    console.log(`Stopping consumer after ${job_timeout} seconds`)
    clearInterval(interval);
}, job_timeout * 1000)

