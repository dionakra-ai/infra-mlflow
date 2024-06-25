module lambda-teste {
    source = "./modules/lambda"
    lambda_repo = "git@github.com:dionakra-ai/lambda-teste.git"
    description = "Lambda de testes"
    function_name = "lambda-teste"
    runtime = "python3.10"
    handler = "main.lambda_handler"
    iam_prefix = "lambda_exec_"
    memory_size = 128
    timeout = 30
    no_build = true
    no_clone = true
    venvs = {
      WORKSPACE = "teste",
    }
}