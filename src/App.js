import { useEffect, useState } from 'react'

const getUsers = async () => {
  const response = await fetch(`${process.env.REACT_APP_BACKEND_URL}/users`)
  return await response.json()
}

const App = () => {
  const [ users, setUsers ] = useState([])

  useEffect(() => {
    getUsers().then(setUsers)
  }, [])

  return (
    <>
      <h1>Frontend</h1>
      <ul>{users.map(user => <li key={user.name}>{user.name}</li>)}</ul>
      <p>Version: 3</p>
    </>
  )
}

export default App
