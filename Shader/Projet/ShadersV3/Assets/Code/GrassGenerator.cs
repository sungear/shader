using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class GrassGenerator : MonoBehaviour
{
    public float minX = -5.0f;
    public float maxX = 5.0f;
    public float minZ = -5.0f;
    public float maxZ = 5.0f;
    public int grassCount = 500;
    public float minWidth = 0.2f;
    public float maxWidth = 0.4f;
    public float minHeight = 0.3f;
    public float maxHeight = 0.5f;

    public float minHue = 0.0f;
    public float maxHue = 0.0f;
    public float minSat = 0.0f;
    public float maxSat = 1.0f;
    public float minVal = 0.0f;
    public float maxVal = 1.0f;

    private Mesh grass;

    public void Generate()
    {
        if (grass != null)
            DestroyImmediate(grass);
        grass = new Mesh();

        int numVertices = grassCount * 4;
        int numTriangles = grassCount * 2;

        Vector3[] vertices = new Vector3[numVertices];
        Vector3[] normals = new Vector3[numVertices];
        Vector2[] uvs = new Vector2[numVertices];
        Color[] colors = new Color[numVertices];
        int[] triangles = new int[numTriangles * 3];

        for (int i = 0; i < grassCount; i++)
        {
            Vector3 spawnPos = new Vector3(Random.Range(minX, maxX),
                                            0.0f,
                                            Random.Range(minZ, maxZ));

            float angle = Random.Range(0.0f, Mathf.PI * 2.0f);

            Vector3 rightPos = new Vector3(Mathf.Sin(angle), 0.0f, Mathf.Cos(angle));
            Vector3 normal = new Vector3(rightPos.z, 0.0f, rightPos.x);
            rightPos *= Random.Range(minWidth, maxWidth);

            float height = Random.Range(minHeight, maxHeight);

            vertices[i * 4] = spawnPos + rightPos;
            vertices[i * 4 + 1] = spawnPos - rightPos;
            vertices[i * 4 + 2] = spawnPos - rightPos + Vector3.up * height;
            vertices[i * 4 + 3] = spawnPos + rightPos + Vector3.up * height;

            normals[i * 4] = normals[i * 4 + 1] = 
                normals[i * 4 + 2] = normals[i * 4 + 3] = normal;

            uvs[i * 4] = new Vector2(1f, 0f);
            uvs[i * 4 + 1] = new Vector2(0f, 0f);
            uvs[i * 4 + 2] = new Vector2(0f, 1f);
            uvs[i * 4 + 3] = new Vector2(1f, 1f);

            Color rndColor = Random.ColorHSV(minHue, maxHue, minSat, maxSat,
                                                minVal, maxVal);
            colors[i * 4] = colors[i * 4 + 1] = rndColor*0.5f;
            colors[i * 4 + 2] = colors[i * 4 + 3] = rndColor;

            int baseIndex = i * 4;

            // Premier triangle en sens anti horlogique
            triangles[i * 6] = baseIndex + 0;
            triangles[i * 6 + 1] = baseIndex + 2;
            triangles[i * 6 + 2] = baseIndex + 1;

            // Second triangle en sens anti horlogique
            triangles[i * 6 + 3] = baseIndex + 0;
            triangles[i * 6 + 4] = baseIndex + 3;
            triangles[i * 6 + 5] = baseIndex + 2;
        }

        grass.vertices = vertices;
        grass.normals = normals;
        grass.uv = uvs;
        grass.triangles = triangles;
        grass.colors = colors;

        grass.RecalculateNormals();

        MeshFilter meshFilter = gameObject.GetComponent<MeshFilter>();
        if (meshFilter == null)
            meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = grass;

        MeshRenderer meshRenderer = gameObject.GetComponent<MeshRenderer>();
        if (meshRenderer == null)
            meshRenderer = gameObject.AddComponent<MeshRenderer>();

    }
}
