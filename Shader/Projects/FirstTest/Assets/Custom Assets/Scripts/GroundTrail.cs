using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GroundTrail : MonoBehaviour {

    public float minDistance = 0.2f;
    public float trailWidth = 0.2f;
    public float uvTiling = 8.0f;
    public Transform movingTarget;

    private List<Vector3> trailPoints = new List<Vector3>();
    private Mesh trail;
    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;

	// Use this for initialization
	void Start () {
        trailPoints.Add(movingTarget.position);

        meshFilter = gameObject.GetComponent<MeshFilter>();
        if (meshFilter == null)
        {
            meshFilter = gameObject.AddComponent<MeshFilter>();
        }

        meshRenderer = gameObject.GetComponent<MeshRenderer>();
        if (meshRenderer == null)
        {
            meshRenderer = gameObject.AddComponent<MeshRenderer>();
        }
    }

    void GenerateMesh()
    {
        if (trail != null)
        {
            Destroy(trail);
        }
        trail = new Mesh();

        int numVertices = 2 * trailPoints.Count;
        int numTriangles = 2 * (trailPoints.Count - 1);

        Vector3[] vertices = new Vector3[numVertices];
        Vector3[] normals = new Vector3[numVertices];
        Vector2[] uvs = new Vector2[numVertices];
        Color[] colors = new Color[numVertices];
        int[] triangles = new int[numTriangles * 3];

        for(int i = 1; i < trailPoints.Count; i++)
        {
            Vector3 trailDirection = trailPoints[i] - trailPoints[i - 1];
            trailDirection.y = 0;
            trailDirection.Normalize();
            Vector3 pointOffset = new Vector3(trailDirection.z, 0, trailDirection.x) * trailWidth;

            if (i == 1)
            {
                vertices[0] = trailPoints[0] - transform.position + pointOffset;
                vertices[1] = trailPoints[0] - transform.position - pointOffset;
                normals[0] = Vector3.up;
                normals[1] = Vector3.up;
                uvs[0] = new Vector2(0, 0);
                uvs[1] = new Vector2(0, 1);
            }

            vertices[i * 2] = trailPoints[i] - transform.position + pointOffset;
            vertices[i * 2 + 1] = trailPoints[i] - transform.position - pointOffset;
            normals[i * 2] = Vector3.up;
            normals[i * 2 + 1] = Vector3.up;
            uvs[i * 2] = new Vector2((float)i / uvTiling, 0);
            uvs[i * 2 + 1] = new Vector2((float)i / uvTiling, 1);

            triangles[(i - 1) * 6] = (i - 1) * 2 + 1;
            triangles[(i - 1) * 6 + 1] = (i - 1) * 2;
            triangles[(i - 1) * 6 + 2] = (i - 1) * 2 + 2;

            triangles[(i - 1) * 6 + 3] = (i - 1) * 2 + 1;
            triangles[(i - 1) * 6 + 4] = (i - 1) * 2 + 2;
            triangles[(i - 1) * 6 + 5] = (i - 1) * 2 + 3;
        }

        trail.vertices = vertices;
        trail.normals = normals;
        trail.uv = uvs;
        trail.triangles = triangles;
        trail.colors = colors;

        trail.RecalculateBounds();

        meshFilter.mesh = trail;
    }	

	// Update is called once per frame
	void Update () {
        Vector3 deltaPosition = movingTarget.position - trailPoints[trailPoints.Count - 1];
        if (deltaPosition.magnitude > minDistance)
        {
            trailPoints.Add(movingTarget.position);
            GenerateMesh();
        }
	}
}
