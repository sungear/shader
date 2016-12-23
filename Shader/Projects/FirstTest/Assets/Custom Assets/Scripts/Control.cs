using UnityEngine;
using System.Collections;

public class Control : MonoBehaviour {

    private Rigidbody myBody;
    public float moveSpeed;

	// Use this for initialization
	void Start () {
        myBody = GetComponent<Rigidbody>();
	}

    // Update is called once per frame
    //Update est appelé au rythme du rendu = 60 fois par seconde
    void Update()
    {
        float speed = myBody.velocity.magnitude;
        speed /= moveSpeed;
        speed = Mathf.Clamp01(speed);
        Shader.SetGlobalVector("_HeroPosition", transform.position);
        Shader.SetGlobalFloat("_HeroSpeed", speed);
    }

    //FixedUpdate est appelé au rythme de 30 fois par seconde
    void FixedUpdate () {
        float HorAxis = Input.GetAxis("Horizontal");
        float VerAxis = Input.GetAxis("Vertical");

        Vector3 moveVelocity = myBody.velocity;
        moveVelocity.x = HorAxis * moveSpeed;
        moveVelocity.z = VerAxis * moveSpeed;
        myBody.velocity = moveVelocity;
    }
}
