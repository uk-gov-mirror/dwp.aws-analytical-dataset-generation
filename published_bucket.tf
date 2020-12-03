data "aws_iam_user" "breakglass" {
  user_name = "breakglass"
}

data "aws_iam_role" "ci" {
  name = "ci"
}

data "aws_iam_role" "administrator" {
  name = "administrator"
}

data "aws_iam_role" "aws_config" {
  name = "aws_config"
}

resource "aws_kms_key" "published_bucket_cmk" {
  description             = "UCFS published Bucket Master Key"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true

  # ProtectsSensitiveData = "False" because, although this bucket is likely to
  # contain PII, its primary form of protection should be CloudHSM-managed
  # key material, meaning a default KMS key policy can be used
  tags = merge(
    local.tags,
    {
      Name = "published_sensitive_cmk"
    },
    {
      ProtectsSensitiveData = "False"
    }
  )
}

resource "aws_kms_alias" "published_bucket_cmk" {
  name          = "alias/published_bucket_cmk"
  target_key_id = aws_kms_key.published_bucket_cmk.key_id
}

output "published_bucket_cmk" {
  value = {
    arn = aws_kms_key.published_bucket_cmk.arn
  }
}

resource "random_id" "published_bucket" {
  byte_length = 16
}

resource "aws_s3_bucket" "published" {
  tags = merge(
    local.tags,
    {
      Name = "published_sensitive"
  })

  bucket = random_id.published_bucket.hex
  acl    = "private"

  versioning {
    enabled = true
  }

  logging {
    target_bucket = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
    target_prefix = "S3Logs/${random_id.published_bucket.hex}/ServerLogs"
  }

  lifecycle_rule {
    id      = ""
    prefix  = "/"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  lifecycle_rule {
    id      = "adg"
    prefix  = "analytical-dataset/"
    enabled = true

    expiration {
      days = 7
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.published_bucket_cmk.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "published" {
  bucket = aws_s3_bucket.published.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

output "published_bucket" {
  value = {
    id  = aws_s3_bucket.published.id
    arn = aws_s3_bucket.published.arn
  }
}

data "aws_iam_policy_document" "published_bucket_https_only" {
  statement {
    sid     = "BlockHTTP"
    effect  = "Deny"
    actions = ["*"]

    resources = [
      aws_s3_bucket.published.arn,
      "${aws_s3_bucket.published.arn}/*",
    ]

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "published_bucket_https_only" {
  bucket     = aws_s3_bucket.published.id
  policy     = data.aws_iam_policy_document.published_bucket_https_only.json
  depends_on = [aws_s3_bucket_public_access_block.published]
}

data "aws_iam_policy_document" "analytical_dataset_generator_write_parquet" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:PutObject*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/analytical-dataset/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "analytical_dataset_generator_write_parquet" {
  name        = "AnalyticalDatasetGeneratorWriteParquet"
  description = "Allow writing of Analytical Dataset parquet files"
  policy      = data.aws_iam_policy_document.analytical_dataset_generator_write_parquet.json
}

data "aws_iam_policy_document" "analytical_dataset_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/analytical-dataset/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "analytical_dataset_read_only" {
  name        = "AnalyticalDatasetReadOnly"
  description = "Allow read access to the Analytical Dataset"
  policy      = data.aws_iam_policy_document.analytical_dataset_read_only.json
}

data "aws_iam_policy_document" "analytical_dataset_crown_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/analytical-dataset/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/collection_tag"

      values = [
        "crown"
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "analytical_dataset_crown_read_only" {
  name        = "AnalyticalDatasetCrownReadOnly"
  description = "Allow read access to the Crown-specific subset of the Analytical Dataset"
  policy      = data.aws_iam_policy_document.analytical_dataset_crown_read_only.json
}

data "aws_iam_policy_document" "analytical_dataset_crown_read_only_non_pii" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/analytical-dataset/*",
      "${aws_s3_bucket.published.arn}/aws-analytical-env-metrics-data/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/Pii"

      values = [
        "false"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/collection_tag"

      values = [
        "crown"
      ]

    }
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "analytical_dataset_crown_read_only_non_pii" {
  name        = "AnalyticalDatasetCrownReadOnlyNonPii"
  description = "Allow read access to the Crown-specific subset of the Analytical Dataset"
  policy      = data.aws_iam_policy_document.analytical_dataset_crown_read_only_non_pii.json
}

# bucket policy for the published non-pii bucket

data "aws_iam_policy_document" "analytical_dataset_generator_read_write_non_pii" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.published_nonsensitive.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:PutObject*",
    ]

    resources = [
      format("arn:aws:s3:::%s/%s/*", data.terraform_remote_state.common.outputs.published_nonsensitive.bucket, local.published_nonsensitive_prefix)
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.published_nonsensitive_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "analytical_dataset_generator_read_write_non_pii" {
  name        = "AnalyticalDatasetGeneratorReadWriteNonPii"
  description = "Allow read writing of non-pii data"
  policy      = data.aws_iam_policy_document.analytical_dataset_generator_read_write_non_pii.json
}

# policy for s3 read access of both non-pii and pii PDM data

data "aws_iam_policy_document" "pdm_read_pii_and_non_pii" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
      data.terraform_remote_state.common.outputs.published_nonsensitive.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/pdm-dataset/*",
      "${aws_s3_bucket.published.arn}/aws-analytical-env-metrics-data/*",
      data.terraform_remote_state.common.outputs.published_nonsensitive.arn,
    ]

  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
      data.terraform_remote_state.common.outputs.published_nonsensitive_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "pdm_read_pii_and_non_pii" {
  name        = "ReadPDMPiiAndNonPii"
  description = "Allow read access to the PDM tables"
  policy      = data.aws_iam_policy_document.pdm_read_pii_and_non_pii.json
}

# policy for s3 read access of non-pii PDM data only

data "aws_iam_policy_document" "pdm_read_non_pii_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.published.arn,
      data.terraform_remote_state.common.outputs.published_nonsensitive.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${aws_s3_bucket.published.arn}/pdm-dataset/*",
      "${aws_s3_bucket.published.arn}/aws-analytical-env-metrics-data/*",
      data.terraform_remote_state.common.outputs.published_nonsensitive.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/pii"

      values = [
        "false"
      ]
    }

  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${aws_kms_key.published_bucket_cmk.arn}",
      data.terraform_remote_state.common.outputs.published_nonsensitive_cmk.arn,
    ]
  }
}

resource "aws_iam_policy" "pdm_read_non_pii_only" {
  name        = "ReadPDMNonPiiOnly"
  description = "Allow read access to a subset of the PDM tables containing less sensitive data called non-pii"
  policy      = data.aws_iam_policy_document.pdm_read_non_pii_only.json
}
