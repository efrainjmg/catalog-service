import { DynamoDBClient, PutItemCommand, ScanCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: process.env.AWS_REGION || "us-east-1" });

export const CATALOG_TABLE = process.env.CATALOG_TABLE_NAME!;

export const saveProduct = async (product: any) => {
  const command = new PutItemCommand({
    TableName: CATALOG_TABLE,
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

export const getAllProducts = async () => {
  const command = new ScanCommand({ TableName: CATALOG_TABLE });
  const result = await client.send(command);
  return result.Items?.map(item => ({
    id: item.id?.S,
    name: item.name?.S,
    description: item.description?.S,
    price: Number(item.price?.N),
    currency: item.currency?.S
  })) || [];
};
