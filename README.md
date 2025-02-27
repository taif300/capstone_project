# capstone_project
# capstone chatbot project

this is my chatbot project 

## how to use it

# Run this command

` streamly run main.py `

Set Up Environment Variables
Store your OpenAI API key in a .env file:

`OPENAI_API_KEY=YOUR-OPENAI-API-KEY`

# Start the Backend
Before running the chatbot, start the FastAPI backend:

`uvicorn backend:app --reload`

# Start the Frontend
Once the backend is running, launch the Streamlit app with:

`streamlit run chatbot.py`