data "aws_eks_cluster" "existing" {
  name = "nodejs-eks-cluster"
}

data "aws_eks_cluster_auth" "existing" {
  name = "nodejs-eks-cluster"
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.existing.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.existing.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.existing.token
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.3.3"

  namespace        = "argocd"
  create_namespace = true
  timeout          = 600
  wait             = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
}
