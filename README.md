# OpenBioC_Execution using Docker-compose
---

## Getting Started 
---
Instructions:
- Clone repository
- Install prerequisites :
    - Docker  https://docs.docker.com/install/linux/docker-ce/ubuntu/
    - Docker-Compose  https://docs.docker.com/compose/install/
- Or Install prerequisites simply running the file `install.sh` (Under construction)

- Run the service
    - You must be in the folder that contains the file to execute this command.

    - `docker-compose up` with logging or `docker-compose up -d` without logging

- Open http://localhost:8080


## Airflow Sub-Commands
---
Run airflow sub-commands in docker-compose:
- List dags :
    - `docker-compose run --rm webserver airflow list_dags`
- Test specific task :
    - `docker-compose run --rm webserver airflow test [DAG_ID] [TASK_ID] [EXECUTION_DATE]`
- Run shell of airflow container :
    - `docker exec -it docker-airflow_airflowserver_1 bash`

## OBC_Client 
---
OpenBioC Client (Flask):

Dag generation,processing etc. remotely via requests from OBC_Server to client( User Executional Environment )

### OBC_Client REST API
---
The REST API to the OpenBioC_Execution is described below.

#### Create Dag file
---
##### **Request**

`POST /generate_dag`

`
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
        "filename":"[Workflow name]",
        "bash":" [Dag file contents] "
        "owner":"[Dag file owner's name]"}' \
  http://0.0.0.0:5000/generate_dag
`
##### **Response**

`
{
  "date": {
    "generate_date": "Sat, 14 Dec 2019 14:32:25 GMT"
  }, 
  "owner": "[Dag file owners name]", 
  "status": "untriggered"
}
`

#### Run Dag file
---
##### **Request**
`POST /trigger_dag`

`
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{
        "dag_name":"[Workflow name]", 
        "owner":"[Dag file owner's name]"}' \
  http://0.0.0.0:5000/trigger_dag
`

##### **Response**







