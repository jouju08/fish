from langchain.globals import set_llm_cache
from langchain_redis import RedisCache


from vectorstore.redis_store import redis_url


redis_cache =RedisCache(redis_url=redis_url)
set_llm_cache(
    redis_cache
)
