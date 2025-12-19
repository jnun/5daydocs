# Project Name

This project uses [5DayDocs](https://github.com/5daydocs/5daydocs) for task and documentation management.

## Quick Start

See `DOCUMENTATION.md` for the complete workflow guide.

### Common Commands

```bash
# Create a new task
./docs/scripts/create-task.sh "Task description"

# Check feature-task alignment
./docs/scripts/analyze-feature-alignment.sh

# View current work
ls docs/tasks/working/

# View sprint queue
ls docs/tasks/next/

# Get AI Context
./docs/scripts/5day.sh ai-context
```

## Project Structure

- `docs/tasks/` - Task pipeline (backlog → next → working → review → live)
- `docs/features/` - Feature documentation with status tracking
- `docs/bugs/` - Bug reports and tracking

---
*Powered by 5DayDocs - Simple, folder-based project management*
