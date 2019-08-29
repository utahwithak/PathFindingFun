using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameLoader : MonoBehaviour
{

    World world;

    // Start is called before the first frame update
    void Start()
    {
        int width = 64, height = 64;

        world = new World(width, height);

        GameObject terrainRendererGO = new GameObject("Terrain Renderer");
        TerrainRenderer terrainRenderer = terrainRendererGO.AddComponent<TerrainRenderer>();
        terrainRenderer.world = world;

    }

    
    void FixedUpdate()
    {
        if (Input.GetMouseButtonDown(0)) {
            CastRayToWorld();
        }
        
    }

    void CastRayToWorld()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        RaycastHit hit;
        if (Physics.Raycast(ray, out hit, Camera.main.farClipPlane))
        {
            //log hit area to the console
            HandleClickPoint(hit.point);
        }

    }

    void HandleClickPoint(Vector3 hit)
    {
        Debug.Log(hit);

    }

}
