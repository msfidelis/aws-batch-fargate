"use strict";

const AWS = require("aws-sdk");
AWS.config.update({ region: "us-east-1" });

const sqs = new AWS.SQS();
const dynamodb = new AWS.DynamoDB();

const queueURL =
  process.env["SQS_QUEUE"] ||
  "https://sqs.us-east-1.amazonaws.com/181560427716/aws-batch-demo";
const job_timeout = process.env["JOB_TIMEOUT"] || 500;
const dynamodb_table = process.env["DYNAMO_TABLE"] || "aws-batch-demo";

const params = {
  AttributeNames: ["SentTimestamp"],
  MaxNumberOfMessages: 10,
  MessageAttributeNames: ["All"],
  QueueUrl: queueURL,
  VisibilityTimeout: 20,
  WaitTimeSeconds: 20,
};

const save = (item) => {
  return new Promise((resolve, reject) => {
    console.log(item);
    const params = {
      Item: {
        Id: {
          S: item.id,
        },
        Name: {
          S: item.name,
        },
        LastName: {
          S: item.last_name,
        },
        Amount: {
          S: item.amount,
        },
        Description: {
          S: item.description,
        },
        Vehicle: {
          S: item.vehicle,
        },
        Country: {
          S: item.country,
        },
      },
      ReturnConsumedCapacity: "TOTAL",
      TableName: dynamodb_table,
    };

    dynamodb.putItem(params, (err, data) => {
      if (err != null) {
        console.log(err);
        reject(err);
      } else {
        resolve(item);
      }
    });
  });
};

const ack = (messages) => {
  // Support to single ACK
  if (Array.isArray(messages) == false) {
    messages = [messages];
  }

  const promisesToResolve = messages.map(async (m) => {
    const params = {
      QueueUrl: queueURL,
      ReceiptHandle: m.ReceiptHandle,
    };
    let d = await sqs.deleteMessage(params).promise();
    return d;
  });

  Promise.all(promisesToResolve)
    .then((success) => {
      console.log("Messages deleted on SQS: ", success);
    })
    .catch((err) => {
      console.log("Error to delete messages", err);
    });
};

var interval = setInterval(() => {
  sqs.receiveMessage(params, (err, data) => {
    if (err) {
      console.log(err);
      interval = null;
    }

    if (data.Messages != undefined) {
      data.Messages.forEach((element, i) => {
        i++;
        let payload = JSON.parse(element.Body);
        console.log("Message consumed", payload.id);
        save(payload)
          .then((success) => {
            console.log("Item saved on Dynamodb:", success.id);
          })
          .catch((err) => console.log);
        if (i == data.Messages.length) {
          ack(data.Messages);
        }
      });
    }
  });
}, 500);

setTimeout(() => {
  console.log(`Stopping consumer after ${job_timeout} seconds`);
  clearInterval(interval);
}, job_timeout * 1000);
