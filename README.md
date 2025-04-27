# SDA-bootcamp-project

Stage 7 - RAG Chatbot(Serverless Backebd)

At this stage, we will move our backend functions to the Azure Function App. Which means we gonna convert the `backend.py` to the Azure Function. We will use **Azure Function V2** here. We also switch the Stream Respons back to normal Http Response since this is a new function added in Azure Function and it will cause issue with incorrent Azure Function Runtime Version.

Another changes is that, in the `upload_pdf` function, we change the temporary store location for pdf file to `/tmp` since this is the only writable path for azure function.

For the database we still use the `advanced_chats` table with following schema:
```
CREATE TABLE IF NOT EXISTS advanced_chats (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    file_path TEXT NOT null,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    pdf_path TEXT,
    pdf_name TEXT,
    pdf_uuid TEXT
)
```

Since we convert to the Azure Function, we need to store the Azure Key Vault name in the `local.settings.json` under the `azure-function` folder. The `local.settings.json` should look like:

```
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "KEY_VAULT_NAME":<YOUR-KEY-VAULT>,
  }
}
```

When deploy to the Azure function, don't forget to upload the `local.settings.json` to the cloud.

And for other credentials, we can still put them in the Azure Key Vault secret.

And since the front-end is still running on the instance and it needs to connect to the Azure Function APP, so let's store the Function URL in the Azure KeyVault as well.
In this case, to allow the front-end able to load the URL from secret, we need to update the front-end codes a little bit and store the `KEY_VAULT_NAME` in the `.env` file on the instance where we run the front-end.
Please make sure your instance has the permission to load the secret from the KeyVault.

Now, the following secrets should be created in your Azure KeyVault:

```
PROJ-DB-NAME
PROJ-DB-USER
PROJ-DB-PASSWORD
PROJ-DB-HOST
PROJ-DB-PORT
PROJ-OPENAI-API-KEY
PROJ-AZURE-STORAGE-SAS-URL
PROJ-AZURE-STORAGE-CONTAINER
PROJ-CHROMADB-HOST
PROJ-CHROMADB-PORT
PROJ-BASE-ENDPOINT-URL
```

The value of PROJ-BASE-ENDPOINT-URL is like `https://<your-function-app-name>.azurewebsites.net/api/`

We still need to run the ChromaDB and streamlit in the VM. Using the follow command to start the Chroma server:
```
chroma run --host 0.0.0.0 --path chromadb
```
change `/db_path` to the path you want to store the data, for example: `chromadb`.

And then use
```
streamlit run chatbot.py
```
to run the streamlit app.
