/*============================================
      KMS Key to Encrypt S3 Bucket
=============================================*/

variable "kms_key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type        = number
  default     = 10
}

variable "kms_key_enable_key_rotation" {
  description = "Specifies whether key rotation is enabled."
  type        = bool
  default     = true
}

/*===================
      S3 Bucket
====================*/

variable "s3_bucket_name" {
  description = "Name for this S3 bucket.  It has to be unique so make it good"
  type = string
  default = "terraform-remote-state-pb0004888"
}

variable "s3_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from S3 buckets so that the buckets can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}


/*============================================
      DynamoDB Table for State Locking
=============================================*/

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to use for state locking."
  type        = string
  default     = "terraform-state-lock-dynamo"
}

variable "dynamodb_table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  type        = string
  default     = "PAY_PER_REQUEST"
}
