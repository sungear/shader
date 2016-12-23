using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class GenericPostEffect : MonoBehaviour
{
    public Material postEffect;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postEffect);
    }
}
