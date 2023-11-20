
import ballerinax/mysql;
import ballerinax/mysql.driver as _; // This bundles the driver to the project so that you don't need to bundle it via the `Ballerina.toml` file.
import ballerina/sql;

configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

final mysql:Client dbClient = check new(
host=HOST, user=USER, password=PASSWORD, port=PORT, database="Pets"
);

type Pet record {|
    int id;
    string name;
    string status;
|};
public function addPets(PetsInputItem[] items) returns error? {

        // Create a batch parameterized query.
        sql:ParameterizedQuery[] insertQueries = from PetsInputItem petObj in items
            select `INSERT INTO Pet (id, name, status)
            VALUES (${petObj.id}, ${petObj.name}, ${petObj.status})`;

        // Insert records in a batch.
        _ = check dbClient->batchExecute(insertQueries);
}

