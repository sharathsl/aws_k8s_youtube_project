#Create IAM role for EKS
resource "aws_iam_role" "eks-iam-role" {
    name = "eksClusterRole"
    
    path = "/"
    
    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
)
}

#Attach policy to the role we created above, The two policies allow you to properly access EC2 instances (where the worker nodes run) and EKS
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    role = aws_iam_role.eks-iam-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
    role = aws_iam_role.eks-iam-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#Create EKS cluster and provide vpc/subnet info
resource "aws_eks_cluster" "eks_cluster" {
  name = "mycluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [ var.subnet1, var.subnet2, var.subnet3, var.subnet4]
  }
  
  depends_on = [ aws_iam_role.eks-iam-role ]
}