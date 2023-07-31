#Set up an IAM role for the worker nodes
resource "aws_iam_role" "eks-worker-role" {
    name = "eksworkerRole"

    assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
)  
}

#attach EKS worker node policies
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    role = aws_iam_role.eks-worker-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    role = aws_iam_role.eks-worker-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    role = aws_iam_role.eks-worker-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.eks-worker-role.name
}

#Create worker nodes
resource "aws_eks_node_group" "worker_nodes" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "eks_workers_group"
    node_role_arn = aws_iam_role.eks-worker-role.arn
    subnet_ids = [ var.subnet1, var.subnet2, var.subnet3, var.subnet4]


    scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}