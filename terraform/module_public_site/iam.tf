# Assume policy document for lambda
data "aws_iam_policy_document" "assume_role_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Policy document to lambda access dynamodb table
data "aws_iam_policy_document" "lambda_execution" {
  statement {
    effect = "Allow"    
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "${aws_dynamodb_table.views.arn}"
    ] 
  }
} 

# Policy document attachement to Policy
resource "aws_iam_policy" "lambda_execution" {
  name        = "lambda_execution-${var.domain_name}"  
  policy      = data.aws_iam_policy_document.lambda_execution.json

  tags = var.common_tags
}

# Role for lambda
resource "aws_iam_role" "lambda_access_dynamodb" {

  name = "lambda_access_dynamodb-${var.domain_name}" 
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda.json
  tags = var.common_tags
  
}

# Atchament between Role and Policy - lambda
resource "aws_iam_role_policy_attachment" "lambda_policy_to_dynamodb" {

  role       = aws_iam_role.lambda_access_dynamodb.name
  policy_arn = aws_iam_policy.lambda_execution.arn
}


#IAM FOR PIPELINES
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

   statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }

}

data "aws_iam_policy_document" "codebuild-iam-policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",      
    ]

    resources = [aws_cloudfront_distribution.www_s3_distribution.arn]
  }

    statement {
    effect = "Allow"

    actions = [
      "lambda:UpdateFunctionCode",      
    ]

    resources = [aws_lambda_function.lambda_function.arn]
  }

  statement {
    effect = "Allow"

    actions = [
            "s3:*"
    ]

    resources = [
        "${aws_s3_bucket.pipelines.arn}",
        "${aws_s3_bucket.pipelines.arn}/*",
        "${aws_s3_bucket.www_bucket.arn}",
        "${aws_s3_bucket.www_bucket.arn}/*"
      ]
  }

  statement {
    effect = "Allow"

    actions = [
            "codecommit:GitPull"
    ]

    resources = [
        aws_codecommit_repository.frontend.arn,
        aws_codecommit_repository.backend.arn,
      ]
  }
 
}

data "aws_iam_policy_document" "codebpipeline-iam-policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",      
    ]

    resources = [aws_cloudfront_distribution.www_s3_distribution.arn]
  }

  statement {
    effect = "Allow"

    actions = [
            "s3:*"
    ]

    resources = [
        "${aws_s3_bucket.pipelines.arn}",
        "${aws_s3_bucket.pipelines.arn}/*",
        "${aws_s3_bucket.www_bucket.arn}",
        "${aws_s3_bucket.www_bucket.arn}/*"
      ]
  }

  statement {
    effect = "Allow"

    actions = [
          "codecommit:GitPull",
          "codecommit:GitPush",
          "codecommit:GetBranch",
          "codecommit:CreateCommit",
          "codecommit:ListRepositories",
          "codecommit:BatchGetCommits",
          "codecommit:BatchGetRepositories",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:ListBranches",
          "codecommit:UploadArchive"
    ]

    resources = [
        aws_codecommit_repository.frontend.arn,
        aws_codecommit_repository.backend.arn
      ]
  }
   
  statement {
    effect = "Allow"

    actions = [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:BatchGetProjects",
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases"
    ]

    resources = [
        aws_codebuild_project.frontend.arn,
        aws_codebuild_project.backend.arn 
      ]
  }

}

data "aws_iam_policy_document" "cloudfront_access_www_bucket" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.www_s3_distribution.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
  }  
}

resource "aws_s3_bucket_policy" "bucket-policy-www" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_access_www_bucket.json
}

resource "aws_iam_role" "codepipeline-role" {
  name               = "codepipeline-role-${var.domain_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "codebuild-role" {
  name               = "codebuild-role-${var.domain_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild-role.name
  policy = data.aws_iam_policy_document.codebuild-iam-policy.json
}

resource "aws_iam_role_policy" "codepipeline" {
  role   = aws_iam_role.codepipeline-role.name
  policy = data.aws_iam_policy_document.codebpipeline-iam-policy.json
}