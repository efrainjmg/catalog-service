export declare const CATALOG_TABLE: string;
export declare const saveProduct: (product: any) => Promise<void>;
export declare const getAllProducts: () => Promise<{
    id: string | undefined;
    name: string | undefined;
    description: string | undefined;
    price: number;
    currency: string | undefined;
}[]>;
//# sourceMappingURL=dynamoClient.d.ts.map