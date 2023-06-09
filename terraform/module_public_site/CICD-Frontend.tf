# AWS caller ID
data "aws_caller_identity" "current" {}

# Create the codecommit REPO for Frontend
resource "aws_codecommit_repository" "frontend" {

  repository_name = "Frontend-${var.domain_name}"
  description     = "Frontend REPO - ${var.domain_name}"
  default_branch = var.codecommit_branch
  
  tags = var.common_tags

}

# Clone and then uplado Frontend code (site) ro REPO
resource "null_resource" "git_upload_frontend" {

  provisioner "local-exec" {

    command = "/bin/bash resources/git_frontend.sh ${aws_codecommit_repository.frontend.clone_url_http}"    
  }
  depends_on = [ aws_codecommit_repository.frontend, aws_lambda_function.lambda_function ]
}

# Create the codebuild for Frontend
resource "aws_codebuild_project" "frontend" {
    name          = "Frontend"
    description   = "Frontend"
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
          name  = "WEBSITE_BUCKET"
          value = aws_s3_bucket.www_bucket.id
      }
        environment_variable {
          name  = "CLOUDFRONT_ID"
          value = aws_cloudfront_distribution.www_s3_distribution.id
      }
    }

   
    
    logs_config {
        cloudwatch_logs {
            group_name  = "log-group"
            stream_name = "log-stream"
        }

        s3_logs {
            status   = "ENABLED"
            location = "${aws_s3_bucket.pipelines.id}/build-log/frontend"
        }
    }

    source {
        type            = "CODECOMMIT"
        location        = aws_codecommit_repository.frontend.clone_url_http                
    }
    
    source_version = "master"

    tags = var.common_tags
}

# Create pipeline for Frontend
resource "aws_codepipeline" "frontend_pipeline" {

  name     = "Pipeline-Frontend-${var.domain_name}"
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
      output_artifacts = ["SourceOutputFE"]
      run_order        = 1

      configuration = {
        RepositoryName       = aws_codecommit_repository.frontend.id
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
      input_artifacts  = ["SourceOutputFE"]
      output_artifacts = ["build_outputFE"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }

}