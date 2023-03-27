#import "Math";

Ray :: struct
{
    origin: Vector3;
    direction: Vector3;
}

Sphere :: struct
{
    center: Vector3;
    radius: float;
}

Hit_Record :: struct 
{
    t: float;
    p: Vector3;
    normal: Vector3;
}

Camera :: struct
{
    origin: Vector3;
    up: Vector3;
    right: Vector3;
    lower_left_corner: Vector3;
}

World :: struct 
{
    spheres: [..] Sphere;
}

get_ray :: (camera: Camera, u: float, v: float) -> Ray
{
    ray: Ray;
    ray.origin = camera.origin;
    ray.direction = camera.lower_left_corner + u*camera.right + v*camera.up - camera.origin;

    return ray;
}

add_sphere :: (world: *World, p: Vector3, r: float)
{
    s: Sphere;
    s.center = p;
    s.radius = r;
    array_add(*world.spheres, s);
}

hit_sphere :: (r: Ray, s: Sphere, t_max: float, hit_rec: *Hit_Record) -> bool
{
    /*  The ray-sphere equation in a nutshell:
        Ray: p(t) = A + t*B
        Sphere: dot((p - c) ,(p - c)) = R*R

        -> dot((p(t)-c), (p(t)-c)) = R*R
        -> dot((A + t*B - C), (A + t*B - C)) = R*R
        -> t*t*dot(B,B) + 2*t*dot(B, A-C) + dot(A-C, A-C) - R*R = 0

        solve for t:
        t = -b - sqrt(b^2-4ac) / 2a
        t = -b + sqrt(b^2-4ac) / 2a
        
        where a = dot(B, B), b = 2*dot(B, A-C), c = dot(A-C, A-C) - R*R

        If the discriminant (b^2-4ac) is negative then there is no intersection.
        If it is zero, the ray is tangent to the sphere.
        If it is positive then there are two points of intersection. 
    */

    a := dot(r.direction, r.direction);
    b := 2*dot(r.direction, r.origin - s.center); 
    c := dot(r.origin - s.center, r.origin - s.center) - s.radius*s.radius;

    discriminant := b*b - 4*a*c;

    if discriminant < 0 return false;

    t1 := (-b - sqrt(discriminant)) / (2*a);
    t2 := (-b + sqrt(discriminant)) / (2*a);

    t_min := 0.0001;

    if t1 < t_max && t1 > t_min
    {
        hit_rec.t = t1;
        hit_rec.p = point_at(r, t1);
        hit_rec.normal = normalize(hit_rec.p - s.center);
        return true;
    }

    if t2 < t_max && t2 > t_min
    {
        hit_rec.t = t2;
        hit_rec.p = point_at(r, t2);
        hit_rec.normal = normalize(hit_rec.p - s.center);
        return true;
    }
    return false;
}

hit_any :: (world: *World, r: Ray, t_max: float, hit_rec: *Hit_Record) -> bool
{
    temp_rec: Hit_Record;
    hit := false;
    closest := t_max;
    for world.spheres 
    {
        if hit_sphere(r, it, closest, *temp_rec)
        {
            hit = true;
            closest = temp_rec.t;
            << hit_rec = temp_rec;
        }
    }

    return hit;
}

point_at :: (ray: Ray, t: float) -> Vector3
{
    return ray.origin + t*ray.direction;
}