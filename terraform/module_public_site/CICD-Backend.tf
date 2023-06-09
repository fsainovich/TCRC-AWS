# AWS caller ID
#data "aws_caller_identity" "current" {}

# Create the codecommit REPO for Backend
resource "aws_codecommit_repository" "backend" {

  repository_name = "Backend-${var.domain_name}"
  description     = "Backend REPO - ${var.domain_name}"
  default_branch = var.codecommit_branch
  
  tags = var.common_tags

}

# Clone and then uplado Frontend code (site) ro REPO
resource "null_resource" "git_upload_backend" {

  provisioner "local-exec" {

    command = "/bin/bash resources/git_backend.sh ${aws_codecommit_repository.backend.clone_url_http}"    
  }
  depends_on = [ aws_codecommit_repository.frontend, aws_lambda_function.lambda_function]
}

# Create the codebuild for Backend
resource "aws_codebuild_project" "backend" {
    name          = "Backend"
    description   = "Backend"
    build_timeout = "5"
    service_role  = aws_iam_role.codebuild-role.arn

    artifacts {
        type = "S3"
        location = aws_s3_bucket.pipelines.bucket
    }
  
    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode             = true

        environment_variable {
          name  = "FUNCTION_NAME"
          value = aws_lambda_function.lambda_function.function_name
        }

        environment_variable {
          name  = "AWS_REGION"
          value = var.aws_region
        }
    }

   
    
    logs_config {
        cloudwatch_logs {
            group_name  = "log-group"
            stream_name = "log-stream"
        }

        s3_logs {
            status   = "ENABLED"
            location = "${aws_s3_bucket.pipelines.id}/build-log/backend"
        }
    }

    source {
        type            = "CODECOMMIT"
        location        = aws_codecommit_repository.backend.clone_url_http                
    }
    
    source_version = "master"

    tags = var.common_tags
}

# Create pipeline for Frontend
resource "aws_codepipeline" "backend_pipeline" {

  name     = "Pipeline-Backend-${var.domain_name}"
  role_arn = aws_iam_role.codepipeline-role.arn
  tags     = var.common_tags

  artifact_store {
    location = aws_s3_bucket.pipelines.bucket
    type     = "S3"    
  }

  stage {
    name = "Source"

    action {
      name             = "Download-Source"
      category         = "Source"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeCommit"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceOutputBE"]
      run_order        = 1

      configuration = {
        RepositoryName       = aws_codecommit_repository.backend.id
        BranchName           = var.codecommit_branch
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceOutputBE"]
      output_artifacts = ["build_outputBE"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.backend.name
      }
    }
  }

}