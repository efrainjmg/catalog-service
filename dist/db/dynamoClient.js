"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllProducts = exports.saveProduct = exports.CATALOG_TABLE = void 0;
const client_dynamodb_1 = require("@aws-sdk/client-dynamodb");
const client = new client_dynamodb_1.DynamoDBClient({ region: process.env.AWS_REGION || "us-east-1" });
exports.CATALOG_TABLE = process.env.CATALOG_TABLE_NAME;
const saveProduct = async (product) => {
    const command = new client_dynamodb_1.PutItemCommand({
        TableName: exports.CATALOG_TABLE,
        Item: {
            id: { S: product.id },
            name: { S: product.name },
            description: { S: product.description },
            price: { N: product.price.toString() },
            currency: { S: product.currency }
        }
    });
    await client.send(command);
};
exports.saveProduct = saveProduct;
const getAllProducts = async () => {
    const command = new client_dynamodb_1.ScanCommand({ TableName: exports.CATALOG_TABLE });
    const result = await client.send(command);
    return result.Items?.map(item => ({
        id: item.id?.S,
        name: item.name?.S,
        description: item.description?.S,
        price: Number(item.price?.N),
        currency: item.currency?.S
    })) || [];
};
exports.getAllProducts = getAllProducts;
//# sourceMappingURL=dynamoClient.js.map