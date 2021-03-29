output "rds_host" {
  value = aws_db_instance.rds.address
}

output "redis_host" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}