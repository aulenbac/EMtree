% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/F_Graphs.R
\name{draw_network}
\alias{draw_network}
\title{Plots a natwork}
\usage{
draw_network(adj_matrix, title = "", size = 4, curv = 0.2,
  width = 1, alpha = FALSE, filter_deg = FALSE, nb = 3,
  layout = NULL, nodes_label = NULL, pal = NULL, seed = 200,
  groupes = NULL)
}
\arguments{
\item{adj_matrix}{graph adjacency matrix}

\item{title}{graph title}

\item{size}{size of nodes}

\item{curv}{edges curvature}

\item{width}{maximum width for the edges}

\item{alpha}{if TRUE, sets to transparent the edges non-linked to nodes with high betweenness}

\item{filter_deg}{selects nodes with a higher degree than filter_deg}

\item{nb}{sets the number of nodes selected by thresholding the beetweenness scores}

\item{layout}{optional ggraph layout.}

\item{nodes_label}{optional labels for nodes.}

\item{pal}{optional palette.}

\item{seed}{optional seed for graph reproductibility.}

\item{groupes}{optional vector seperating the nodes into groupes}
}
\value{
\itemize{
\item{G} {the network as a ggplot2 object, with highlighted high betweenness nodes}
\item{graph_data}{ data needed for plotting the network}
}
}
\description{
Plots a natwork
}
\examples{
adj_matrix= SimCluster(p=30,k=3,dens=0.4, r=50)
draw_network(adj_matrix,"Cluster graph", layout="fr",curv=0.1)
}
