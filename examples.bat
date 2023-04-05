using System.IO;
using Microsoft.AspNetCore.Mvc;

[ApiController]
public class ConfigsController : ControllerBase
{
    // GET: /Configs/config.xml
    [HttpGet("Configs/config.xml")]
    [Produces("application/xml")]
    public IActionResult Get()
    {
        string filePath = Path.Combine(Directory.GetCurrentDirectory(), "config.xml");

        if (!System.IO.File.Exists(filePath))
        {
            return NotFound();
        }

        string fileContents = System.IO.File.ReadAllText(filePath);

        return Content(fileContents);
    }
}
