#import "Math";

Ray :: struct
{
    origin: Vector3;
    direction: Vector3;
}

point_at :: (ray: Ray, t: float) -> Vector3
{
    return ray.origin + t*ray.direction;
}