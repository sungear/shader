using UnityEngine;
using System.Collections;

public class Control : MonoBehaviour
{
    private Rigidbody mybody;
    public float MoveSpeed;

    void Start ()
	{
	    mybody = GetComponent<Rigidbody>();
	}

    void Update()
    {
        float speed = mybody.velocity.magnitude;
        speed /= MoveSpeed;
        speed = Mathf.Clamp01(speed);

        Shader.SetGlobalVector("_HeroPosition", transform.position);
        Shader.SetGlobalFloat("_HeroSpeed", speed);
    }

    void FixedUpdate ()
	{
	    float horAxis = Input.GetAxis("Horizontal");
	    float verAxis = Input.GetAxis("Vertical");

	    Vector3 moveVelocity = mybody.velocity;

	    moveVelocity.x = horAxis*MoveSpeed;
	    moveVelocity.z = verAxis*MoveSpeed;

	    mybody.velocity = moveVelocity;
	}
}
