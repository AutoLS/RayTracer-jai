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

hit_sphere :: (r: Ray, s: Sphere) -> bool
{
    /*  The ray-sphere equation in a nutshell:
        Ray: p(t) = A + t*B
        Sphere: dot((p - c) ,(p - c)) = R*R

        -> dot((p(t)-c), (p(t)-c)) = R*R
        -> dot((A + t*B - C), (A + t*B - C)) = R*R
        -> t*t*dot(B,B) + 2*t*dot(B, A-C) + dot(A-C, A-C) - R*R = 0

        solve for t:
        t = -b + sqrt(b^2-4ac) / 2a
        t = -b - sqrt(b^2-4ac) / 2a
        
        where a = dot(B, B), b = 2*dot(B, A-C), c = dot(A-C, A-C) - R*R

        If the discriminant (b^2-4ac) is negative then there is no intersection.
        If it is zero, the ray is tangent to the sphere.
        If it is positive then there are two points of intersection. 
    */

    a := dot(r.direction, r.direction);
    b := 2*dot(r.direction, r.origin - s.center); 
    c := dot(r.origin - s.center, r.origin - s.center) - s.radius*s.radius;

    discriminant := b*b - 4*a*c;
    return discriminant > 0;
}

point_at :: (ray: Ray, t: float) -> Vector3
{
    return ray.origin + t*ray.direction;
}