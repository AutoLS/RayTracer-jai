random_in_unit_sphere :: () -> Vector3
{
    p: Vector3 = 2.0*make_vector3(random_get_zero_to_one_open(), random_get_zero_to_one_open(), random_get_zero_to_one_open()) - Vector3.{1, 1, 1};

    while dot(p, p) >= 1 
    {
        p = 2.0*make_vector3(random_get_zero_to_one_open(), random_get_zero_to_one_open(), random_get_zero_to_one_open()) - Vector3.{1, 1, 1};
    }

    return p;
}