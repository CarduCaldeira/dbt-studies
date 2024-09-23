Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

------------------------------------------------------------------------------------------------------------

# Instalação

Este é um projeto baseado nos meus estudos realizados a partir do curso https://www.udemy.com/course/complete-dbt-data-build-tool-bootcamp-zero-to-hero-learn-dbt. Os dados utilizados nesse curso sao disponibilizados
pelo curso atraves de um arquivo .csv, baixado via acesso ao S3. Para utilizar o dbt é necessário a escolha de um conector (ou mais de um) que será
utilizado para integração a base de dados, que nesse curso será o Snowflake, portanto apos criar um ambiente virtual instale:

```
pip install dbt-snowflake
```
E execute:
```
dbt init
```
Neste momento sera necessario informar configurações referente ao projeto e do seu datawarehouse no snowflake, como o usuario, senha, role, datawarehouse, database e schema default. Após esta etapa o dbt criara uma pasta com o nome do seu projeto com a seguinte estrutura:

```
├── analyses
├── dbt_packages
├── dbt_project.yml
├── logs
├── macros
├── models
├── README.md
├── seeds
├── snapshots
├── target
└── tests
```
O arquivo dbt_project.yml possui as configurações gerais do projeto.

-----------------------------------------------------------------------------------
## Models

A pasta models é onde os scripts sql serão deixados, a saída da query sera 
materializado em uma view por padrão, porém caso especificado poder
materializado em uma table, incremental ou ephemeral. Tais especificações
podem ser feitas a nivel de script, com o comando no inicio do script:
```
{{ 
  config(
    materialized='table', 
    schema='meu_schema_personalizado'
  ) 
}}
```
Que por exemplo define uma table em uma schema que não é o default, ou a nível
de pasta no arquivo dbt-project.yml. Por exemplo, para a pasta models/dim pode 
ser definido que o a matrialization default é table com as configurações:
```
models:
  dbtlearn:
      +materialized: view
      dim:
        +materialized: table
```
Após adicionar os scripts SQL basta dar o comando 
```
dbt run
```

Na pasta models/src são criadas as views SRC_LISTINGS, SRC_REVIEWS e SRC_HOSTS no database no snowflake e nas pastas dim sao aplicados transformações utilizando o jinja para referencia-las. 
-----------------------------------------------------------------------
## Incremental

Um caso comum são dados que são adicionados de forma periódica,por padrão o DBT sobreescrve as tabelas/views e portanto no caso em que esse comportamento não é desejado a sua materialização tem que ser a Incremental.

```
{{
  config(
    materialized = 'incremental',
    on_schema_change='fail'
    )
}}
WITH src_reviews AS (
  SELECT * FROM {{ ref('src_reviews') }}
)
SELECT * FROM src_reviews
WHERE review_text is not null

{% if is_incremental() %}
  AND review_date > (select max(review_date) from {{ this }})
{% endif %}
```
Note que sobre o resultado do select é aplicado uma condição para quais linhas serão adiconadas/atualizadas.

-----------------------------------------------------------------------
## Ephemeral

Tabalas Ephemeral são tabelas que nao são escritas no banco de dados, poupando espaço de armazenamendo, 
por outro lado, nao é aconselhavel utilizalas  em casos de transformações elaboradas visto que será necessário 
refazer essas transformações.

-------------------------------------------------------------------------
## Seed

Para adicionar fonte da dados diretamente de arquivos podemos usar as seeds, na pasta seeds adicione o arquivo e de o comando:
```
dbt seed
```
Isso ira criar a table a partir dos arquivos na pasta seed.

-> Commmit = "Initial Structure"
-------------------------------------------------------------------------
## Source