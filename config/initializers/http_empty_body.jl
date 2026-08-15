import Base.copy
import HTTP

# Genie 6.0.4 copies payloads for PUT requests before checking their length.
# HTTP 2.6 represents an omitted body as EmptyBody, which has no copy method.
copy(::HTTP.EmptyBody) = UInt8[]
