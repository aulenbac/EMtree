library(tibble)
library(ggplot2)
library(PLNmodels)
library(parallel)
library(dplyr)
library(vegan)
library(Matrix)
library(mvtnorm)
library(tidyr)
library(EMtree)
##########################
n=30
p=10
S=5
##########################
Y=data_from_scratch("tree",p=p,n=n)$data
beta = matrix(1/10,10,10)
gamma=log(beta)
psi=Psi_alpha(cor(Y), n)$psi
P=EdgeProba(beta*psi)
M=Meila(beta)
x=SetLambda(P,M)
covar=data.frame(rnorm(10,n))
##########################
FitEM = FitBetaStatic(beta.init=beta, psi=psi, maxIter = 6,
                      verbatim=TRUE, plot=TRUE)
PLNobj = PLN(Y~1)
EM=EMtree(PLN.Cor =PLNobj, plot=FALSE, verbatim=FALSE)
resampl=ResampleEMtree(Y, S=S,cores = 1)

X = data.frame(V1=rnorm(n),V2=rbinom(n,1,0.7))
compare=ComparEMtree(Y,X,models=list(1,2),m_names=list("1","2"),Pt=0.3,S=S, cores=1)

##########################
test_that("SetLambda", {
  expect_equal(abs( 1 - sum(P / (x+M)))<1e-5, TRUE )
})
test_that("equiv versions of likelihood", {
  expect_equal(F_NegLikelihood(F_Sym2Vec(beta), log(psi),P),
               F_NegLikelihood_Trans(F_Sym2Vec(gamma),log(psi),P, trim=FALSE) )
})
test_that("FitEM", {
  expect_equal(FitEM$logpY[FitEM$maxIter]>FitEM$logpY[FitEM$maxIter-1],TRUE)
})
test_that("EMtree() raise an error for PLN.Cor argument", {
  expect_error(EMtree(covar, plot = FALSE, verbatim = FALSE))
  expect_error(EMtree(EMtree(cov2cor(PLNobj$model_par$Sigma)[1:9,], plot = FALSE, verbatim = FALSE)))
  expect_error(EMtree(EMtree(cov2cor(PLNobj$model_par$Sigma)[,1:9], plot = FALSE, verbatim = FALSE)))
})
test_that("EMtree.logpY", {
  expect_equal(EM$logpY[EM$maxIter]>EM$logpY[EM$maxIter-1],TRUE)
})
test_that("EMtree.dim", {
  expect_equal(dim(EM$edges_weight)==dim(EM$edges_prob),c(TRUE,TRUE))
})
test_that("ResampleEMtree", {
  expect_equal(rowSums(resampl$Pmat),rep(2*(p-1)/2,S))
})



test_that("ComparEMtree", {
  expect_equal(dim(compare),c(p*(p-1),4))
})
