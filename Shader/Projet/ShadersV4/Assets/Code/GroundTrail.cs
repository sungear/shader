using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class GroundTrail : MonoBehaviour
{
    public float minimalDistance = 0.2f;
    public float trailWidth = 0.2f;
    public float uvTiling = 8.0f;
    public int maxTrailLength = 50;
    public Transform movingTarget;

    private List<Vector3> trailingPoints = new List<Vector3>();
    private Mesh trail;
    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;
    private int uvOffset = 0;

	void Start ()
    {
        trailingPoints.Add(movingTarget.position);

        meshFilter = gameObject.GetComponent<MeshFilter>();
        if (meshFilter == null)
            meshFilter = gameObject.AddComponent<MeshFilter>();

        meshRenderer = gameObject.GetComponent<MeshRenderer>();
        if (meshRenderer == null)
            meshRenderer = gameObject.AddComponent<MeshRenderer>();
    }
	
    void GenerateMesh()
    {
        if (trail != null)
            Destroy(trail);

        trail = new Mesh();

        int numVertices = 2 * trailingPoints.Count;
        int numTriangles = 2 * (trailingPoints.Count-1);

        Vector3[] vertices = new Vector3[numVertices];
        Vector3[] normals = new Vector3[numVertices];
        Vector2[] uvs = new Vector2[numVertices];
        Color[] colors = new Color[numVertices];
        int[] triangles = new int[numTriangles * 3];

        for(int i=1; i < trailingPoints.Count; i++)
        {
            Vector3 trailDirection = trailingPoints[i] - trailingPoints[i - 1];
            trailDirection.y = 0.0f;
            trailDirection.Normalize();

            Vector3 verticalOffset = new Vector3(0f, (float)i * 0.0001f, 0f);

            Vector3 pointOffset = new Vector3(-trailDirection.z, 0f, trailDirection.x) *
                                trailWidth;
            if (i==1)
            {
                vertices[0] = trailingPoints[0] + verticalOffset - transform.position  + pointOffset;
                vertices[1] = trailingPoints[0] + verticalOffset - transform.position - pointOffset;
                normals[0] = Vector3.up;
                normals[1] = Vector3.up;
                uvs[0] = new Vector2((float)uvOffset / uvTiling, 0.0f);
                uvs[1] = new Vector2((float)uvOffset / uvTiling, 1.0f);
            }

            vertices[i * 2] = trailingPoints[i] + verticalOffset - transform.position + pointOffset;
            vertices[i * 2 + 1] = trailingPoints[i] + verticalOffset - transform.position - pointOffset;
            normals[i * 2] = Vector3.up;
            normals[i * 2 + 1] = Vector3.up;
            uvs[i * 2] = new Vector2((float)(i+ uvOffset) / uvTiling, 0.0f);
            uvs[i * 2 + 1] = new Vector2((float)(i+ uvOffset) / uvTiling, 1.0f);

            triangles[(i - 1) * 6]     = (i - 1) * 2 + 1;
            triangles[(i - 1) * 6 + 1] = (i - 1) * 2;
            triangles[(i - 1) * 6 + 2] = (i - 1) * 2 + 2;
                                
            triangles[(i - 1) * 6 + 3] = (i - 1) * 2 + 1;
            triangles[(i - 1) * 6 + 4] = (i - 1) * 2 + 2;
            triangles[(i - 1) * 6 + 5] = (i - 1) * 2 + 3;
        }

        trail.vertices = vertices;
        trail.normals = normals;
        trail.uv = uvs;
        trail.colors = colors;
        trail.triangles = triangles;

        trail.RecalculateBounds();

        meshFilter.mesh = trail;
    }

	void Update ()
    {
        Vector3 deltaPosition = movingTarget.position - trailingPoints[trailingPoints.Count - 1];
        
        if (deltaPosition.magnitude > minimalDistance)
        {
            trailingPoints.Add(movingTarget.position);
            if (trailingPoints.Count > maxTrailLength)
            {
                trailingPoints.RemoveAt(0);
                uvOffset++;
            }
            GenerateMesh();
        }
    }
}
